const oracledb = require('oracledb');

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
oracledb.autoCommit = true;

const dbConfig = {
  user: process.env.DB_USER || 'system',
  password: process.env.DB_PASSWORD || '123',
  connectString: `${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || 1521}/${process.env.DB_SID || 'xe'}`
};

let connection;

const initDatabase = async () => {
  try {
    connection = await oracledb.getConnection(dbConfig);
    console.log('Connected to Oracle Database');
    
    // Create sequences first
    await connection.execute(`
      BEGIN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE users_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE != -955 THEN
            RAISE;
          END IF;
      END;
    `);

    await connection.execute(`
      BEGIN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE transactions_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE != -955 THEN
            RAISE;
          END IF;
      END;
    `);

    await connection.execute(`
      BEGIN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE goals_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE != -955 THEN
            RAISE;
          END IF;
      END;
    `);

    // Check and create tables
    await checkAndCreateUsersTable();
    await checkAndCreateTransactionsTable();
    await checkAndCreateGoalsTable();
    
    // Create stored procedures
    await createProcedures(connection);
    
    console.log('Database initialized successfully');
    return connection;
  } catch (error) {
    console.error('Database initialization error:', error);
    throw error;
  }
};

// Function to create stored procedures
const createProcedures = async (connection) => {
  try {
    // Procedure 1: Monthly Expenditure Analysis
    await connection.execute(`
      CREATE OR REPLACE PROCEDURE get_monthly_expenditure_analysis(
        p_user_id IN NUMBER,
        p_year IN NUMBER,
        p_result OUT SYS_REFCURSOR
      ) AS
      BEGIN
        OPEN p_result FOR
        SELECT
          EXTRACT(MONTH FROM transaction_date) AS month_number,
          TO_CHAR(transaction_date, 'Month') AS month_name,
          COUNT(*) AS transaction_count,
          SUM(amount) AS total_amount,
          AVG(amount) AS avg_amount,
          CASE
            WHEN LAG(SUM(amount)) OVER (ORDER BY EXTRACT(MONTH FROM transaction_date)) IS NULL THEN 'No previous data'
            WHEN SUM(amount) > LAG(SUM(amount)) OVER (ORDER BY EXTRACT(MONTH FROM transaction_date)) THEN 'Increase'
            WHEN SUM(amount) < LAG(SUM(amount)) OVER (ORDER BY EXTRACT(MONTH FROM transaction_date)) THEN 'Decrease'
            ELSE 'Same'
          END AS trend
        FROM transactions
        WHERE user_id = p_user_id
          AND type = 'expense'
          AND EXTRACT(YEAR FROM transaction_date) = p_year
        GROUP BY EXTRACT(MONTH FROM transaction_date), TO_CHAR(transaction_date, 'Month')
        HAVING SUM(amount) > 0
        ORDER BY EXTRACT(MONTH FROM transaction_date);
      END;
    `);

    // Procedure 2: Goal Adherence Tracking
    await connection.execute(`
      CREATE OR REPLACE PROCEDURE get_goal_adherence_tracking(
        p_user_id IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_result OUT SYS_REFCURSOR
      ) AS
      BEGIN
        OPEN p_result FOR
        WITH monthly_data AS (
          SELECT
            g.id AS goal_id,
            g.target_month,
            g.target_year,
            g.target_amount,
            SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE -t.amount END) AS actual_net_income
          FROM goals g
          LEFT JOIN transactions t ON g.user_id = t.user_id
            AND EXTRACT(MONTH FROM t.transaction_date) = g.target_month
            AND EXTRACT(YEAR FROM t.transaction_date) = g.target_year
          WHERE g.user_id = p_user_id
            AND TO_DATE(g.target_month || '-' || g.target_year, 'MM-YYYY') BETWEEN p_start_date AND p_end_date
          GROUP BY g.id, g.target_month, g.target_year, g.target_amount
        )
        SELECT
          goal_id,
          target_month,
          target_year,
          target_amount,
          NVL(actual_net_income, 0) AS actual_amount,
          NVL(actual_net_income, 0) - target_amount AS difference,
          ROUND((NVL(actual_net_income, 0) / target_amount) * 100, 2) AS achievement_percentage,
          CASE
            WHEN NVL(actual_net_income, 0) >= target_amount THEN 'Achieved'
            WHEN NVL(actual_net_income, 0) >= (target_amount * 0.8) THEN 'Near Target'
            ELSE 'Below Target'
          END AS status
        FROM monthly_data
        ORDER BY target_year, target_month;
      END;
    `);

    // Procedure 3: Savings Goal Progress
    await connection.execute(`
      CREATE OR REPLACE PROCEDURE get_savings_goal_progress(
        p_user_id IN NUMBER,
        p_result OUT SYS_REFCURSOR
      ) AS
      BEGIN
        OPEN p_result FOR
        WITH goal_progress AS (
          SELECT
            g.id,
            g.target_month,
            g.target_year,
            g.target_amount,
            SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE -t.amount END) AS current_amount,
            ROUND((SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE -t.amount END) / g.target_amount) * 100, 2) AS progress_percentage,
            g.target_amount - SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE -t.amount END) AS remaining_amount
          FROM goals g
          LEFT JOIN transactions t ON g.user_id = t.user_id
            AND EXTRACT(MONTH FROM t.transaction_date) = g.target_month
            AND EXTRACT(YEAR FROM t.transaction_date) = g.target_year
          WHERE g.user_id = p_user_id
          GROUP BY g.id, g.target_month, g.target_year, g.target_amount
        )
        SELECT
          id,
          target_month,
          target_year,
          target_amount,
          NVL(current_amount, 0) AS current_amount,
          NVL(progress_percentage, 0) AS progress_percentage,
          NVL(remaining_amount, target_amount) AS remaining_amount,
          CASE
            WHEN current_amount >= target_amount THEN 'Achieved'
            WHEN TO_DATE(target_month || '-' || target_year, 'MM-YYYY') < TRUNC(SYSDATE) AND current_amount < target_amount THEN 'Overdue'
            WHEN progress_percentage >= 90 THEN 'Near Goal'
            ELSE 'In Progress'
          END AS status,
          CASE
            WHEN TO_DATE(target_month || '-' || target_year, 'MM-YYYY') > SYSDATE THEN
              ROUND((target_amount - NVL(current_amount, 0)) / GREATEST(1, (TO_DATE(target_month || '-' || target_year, 'MM-YYYY') - SYSDATE)), 2)
            ELSE 0
          END AS required_daily_saving
        FROM goal_progress
        ORDER BY target_year, target_month;
      END;
    `);

    // Procedure 4: Category Expense Distribution
    await connection.execute(`
      CREATE OR REPLACE PROCEDURE get_category_expense_distribution(
        p_user_id IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_result OUT SYS_REFCURSOR
      ) AS
        v_total_expenses NUMBER := 0;
      BEGIN
        SELECT NVL(SUM(amount), 0) INTO v_total_expenses
        FROM transactions
        WHERE user_id = p_user_id
          AND type = 'expense'
          AND transaction_date BETWEEN p_start_date AND p_end_date;

        OPEN p_result FOR
        SELECT
          category AS category_name,
          COUNT(*) AS transaction_count,
          SUM(amount) AS total_amount,
          AVG(amount) AS avg_amount,
          CASE
            WHEN v_total_expenses > 0 THEN
              ROUND((SUM(amount) / v_total_expenses) * 100, 2)
            ELSE 0
          END AS percentage_of_total
        FROM transactions
        WHERE user_id = p_user_id
          AND type = 'expense'
          AND transaction_date BETWEEN p_start_date AND p_end_date
        GROUP BY category
        HAVING SUM(amount) > 0
        ORDER BY SUM(amount) DESC;
      END;
    `);

    // Procedure 5: Financial Health Status
    await connection.execute(`
      CREATE OR REPLACE PROCEDURE get_financial_health_status(
        p_user_id IN NUMBER,
        p_result OUT SYS_REFCURSOR
      ) AS
        v_total_income NUMBER := 0;
        v_total_expenses NUMBER := 0;
        v_net_income NUMBER := 0;
        v_savings_rate NUMBER := 0;
      BEGIN
        SELECT
          NVL(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0),
          NVL(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0)
        INTO v_total_income, v_total_expenses
        FROM transactions
        WHERE user_id = p_user_id;

        v_net_income := v_total_income - v_total_expenses;
        v_savings_rate := CASE WHEN v_total_income > 0 THEN (v_net_income / v_total_income) * 100 ELSE 0 END;

        OPEN p_result FOR
        SELECT
          v_total_income AS total_income,
          v_total_expenses AS total_expenses,
          v_net_income AS net_income,
          ROUND(v_savings_rate, 2) AS savings_rate,
          CASE
            WHEN v_savings_rate >= 20 THEN 'Excellent'
            WHEN v_savings_rate >= 10 THEN 'Good'
            WHEN v_savings_rate >= 0 THEN 'Needs Improvement'
            ELSE 'Critical'
          END AS financial_health,
          (SELECT COUNT(*) FROM transactions WHERE user_id = p_user_id) AS total_transactions,
          (SELECT COUNT(*) FROM goals WHERE user_id = p_user_id) AS total_goals,
          (SELECT COUNT(*) FROM goals WHERE user_id = p_user_id 
           AND target_amount <= (SELECT SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END)
                               FROM transactions 
                               WHERE user_id = p_user_id
                               AND EXTRACT(MONTH FROM transaction_date) = target_month
                               AND EXTRACT(YEAR FROM transaction_date) = target_year)) AS achieved_goals
        FROM DUAL;
      END;
    `);

    console.log('All procedures created successfully');
  } catch (error) {
    console.error('Error creating procedures:', error);
    throw error;
  }
};

// Function to check and create users table
const checkAndCreateUsersTable = async () => {
  try {
    const tableExists = await connection.execute(`
      SELECT table_name 
      FROM user_tables 
      WHERE table_name = 'USERS'
    `);

    if (tableExists.rows.length === 0) {
      await createUsersTable();
      return;
    }

    const requiredColumns = [
      'ID', 'NAME', 'EMAIL', 'PASSWORD', 'DATE_OF_BIRTH', 
      'IS_ACTIVE', 'LAST_LOGIN', 'CREATED_AT'
    ];

    const existingColumns = await connection.execute(`
      SELECT column_name 
      FROM user_tab_columns 
      WHERE table_name = 'USERS'
    `);

    const existingColumnNames = existingColumns.rows.map(row => row.COLUMN_NAME);
    const missingColumns = requiredColumns.filter(col => !existingColumnNames.includes(col));

    if (missingColumns.length > 0) {
      console.log(`Missing columns in USERS table: ${missingColumns.join(', ')}`);
      console.log('Dropping and recreating USERS table...');
      
      await connection.execute('DROP TABLE users CASCADE CONSTRAINTS');
      await createUsersTable();
    } else {
      console.log('USERS table exists with all required columns');
    }

  } catch (error) {
    console.error('Error checking/creating users table:', error);
    throw error;
  }
};

// Function to create users table
const createUsersTable = async () => {
  await connection.execute(`
    CREATE TABLE users (
      id NUMBER PRIMARY KEY,
      name VARCHAR2(100) NOT NULL,
      email VARCHAR2(255) UNIQUE NOT NULL,
      password VARCHAR2(255) NOT NULL,
      date_of_birth DATE NOT NULL,
      is_active NUMBER(1) DEFAULT 1,
      last_login TIMESTAMP,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
  console.log('Created USERS table');
};

// Function to check and create transactions table
const checkAndCreateTransactionsTable = async () => {
  try {
    const tableExists = await connection.execute(`
      SELECT table_name 
      FROM user_tables 
      WHERE table_name = 'TRANSACTIONS'
    `);

    if (tableExists.rows.length === 0) {
      await createTransactionsTable();
      return;
    }

    const requiredColumns = [
      'ID', 'AMOUNT', 'DESCRIPTION', 'TYPE', 'CATEGORY', 
      'USER_ID', 'DATE_CREATED', 'TRANSACTION_DATE'
    ];

    const existingColumns = await connection.execute(`
      SELECT column_name 
      FROM user_tab_columns 
      WHERE table_name = 'TRANSACTIONS'
    `);

    const existingColumnNames = existingColumns.rows.map(row => row.COLUMN_NAME);
    const missingColumns = requiredColumns.filter(col => !existingColumnNames.includes(col));

    if (missingColumns.length > 0) {
      console.log(`Missing columns in TRANSACTIONS table: ${missingColumns.join(', ')}`);
      console.log('Dropping and recreating TRANSACTIONS table...');
      
      await connection.execute('DROP TABLE transactions CASCADE CONSTRAINTS');
      await createTransactionsTable();
    } else {
      console.log('TRANSACTIONS table exists with all required columns');
      
      try {
        const fkExists = await connection.execute(`
          SELECT constraint_name 
          FROM user_constraints 
          WHERE table_name = 'TRANSACTIONS' 
          AND constraint_name = 'FK_USER_TRANSACTION'
        `);
        
        if (fkExists.rows.length === 0) {
          console.log('Adding foreign key constraint...');
          await connection.execute(`
            ALTER TABLE transactions 
            ADD CONSTRAINT fk_user_transaction 
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          `);
        }
      } catch (fkError) {
        console.log('Error checking/adding foreign key:', fkError.message);
      }
    }

  } catch (error) {
    console.error('Error checking/creating transactions table:', error);
    throw error;
  }
};

// Function to create transactions table
const createTransactionsTable = async () => {
  await connection.execute(`
    CREATE TABLE transactions (
      id NUMBER PRIMARY KEY,
      amount NUMBER NOT NULL,
      description VARCHAR2(500) NOT NULL,
      type VARCHAR2(10) NOT NULL,
      category VARCHAR2(100) NOT NULL,
      user_id NUMBER NOT NULL,
      date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      transaction_date DATE NOT NULL,
      CONSTRAINT fk_user_transaction FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);
  console.log('Created TRANSACTIONS table with foreign key constraint');
};

// Function to check and create goals table
const checkAndCreateGoalsTable = async () => {
  try {
    const tableExists = await connection.execute(`
      SELECT table_name 
      FROM user_tables 
      WHERE table_name = 'GOALS'
    `);

    if (tableExists.rows.length === 0) {
      await createGoalsTable();
      return;
    }

    console.log('GOALS table already exists');

  } catch (error) {
    console.error('Error checking/creating goals table:', error);
    throw error;
  }
};

// Function to create goals table
const createGoalsTable = async () => {
  await connection.execute(`
    CREATE TABLE goals (
      id NUMBER PRIMARY KEY,
      user_id NUMBER NOT NULL,
      target_amount NUMBER NOT NULL,
      target_month NUMBER NOT NULL,
      target_year NUMBER NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      CONSTRAINT fk_user_goal FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      CONSTRAINT unique_user_month_goal UNIQUE (user_id, target_month, target_year)
    )
  `);
  console.log('Created GOALS table');
};

const getConnection = async () => {
  try {
    if (!connection) {
      connection = await oracledb.getConnection(dbConfig);
    }
    return connection;
  } catch (error) {
    console.error('Error getting database connection:', error);
    throw error;
  }
};

const closeConnection = async () => {
  if (connection) {
    try {
      await connection.close();
      console.log('Database connection closed');
    } catch (error) {
      console.error('Error closing connection:', error);
    }
  }
};

module.exports = {
  initDatabase,
  getConnection,
  closeConnection
};