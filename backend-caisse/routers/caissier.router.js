const router = require ('express').Router();
const CaissierController = require("../controller/caissier.controller")

router.post('/registerCaissier',CaissierController.register);
router.post('/LoginCaissier',CaissierController.login);
router.get('/allCaissiers', CaissierController.getAllCaissiers);
router.get('/CountCaissiers', CaissierController.countCaissiers);

router.delete('/deleteCaissier/:email', CaissierController.deleteCaissier);
router.put('/updateCaissier', CaissierController.updateCaissier);
router.get('/getCashierByEmail/:email', CaissierController.getCashierByEmail);

module.exports = router;