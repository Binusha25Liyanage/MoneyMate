const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const { authenticateToken } = require('../middleware/authMiddleware');

router.get('/report', authenticateToken, reportController.generateReport);
router.get('/report/yearly', authenticateToken, reportController.getYearlyReport);

// New report routes
router.get('/report/monthly-expenditure', authenticateToken, reportController.monthlyExpenditureAnalysis);
router.get('/report/goal-adherence', authenticateToken, reportController.goalAdherenceTracking);
router.get('/report/savings-progress', authenticateToken, reportController.savingsGoalProgress);
router.get('/report/category-distribution', authenticateToken, reportController.categoryExpenseDistribution);
router.get('/report/financial-health', authenticateToken, reportController.financialHealthStatus);

module.exports = router;