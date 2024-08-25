const router = require ('express').Router();
const AdminController = require("../controller/admin.controller")

router.post('/registerAdmin',AdminController.register);
router.post('/LoginAdmin',AdminController.login);
module.exports = router;