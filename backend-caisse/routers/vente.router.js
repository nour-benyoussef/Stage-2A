const router = require('express').Router();
const VenteController = require('../controller/vente.controller');

router.post('/registerVente', VenteController.register);
router.get('/allVentes', VenteController.getAllVentes);
router.get('/Countventes', VenteController.countVentes);

module.exports = router;
