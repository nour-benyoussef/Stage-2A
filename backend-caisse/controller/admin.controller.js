const AdminService = require("../services/admin.services");

exports.register = async (req, res, next) => {
  try {
    const {email, Mot_De_Passe } = req.body;
    const successRes = await AdminService.registerAdmin(
      email,
      Mot_De_Passe,
    );

    res.json({ status: true, success: "Admin enregistré" });
  } catch (error) {
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, Mot_De_Passe } = req.body;

    const admin = await AdminService.checkAdmin(email);

    if (!admin) {
      return res.status(404).json({ status: false, message: "identifiant incorrect " });
    }

    const isMatch = await admin.comparePassword(Mot_De_Passe);

    if (!isMatch) {
      return res.status(401).json({ status: false, message: "Mot de passe incorrect" });
    }

    let tokenData = { _id: admin._id, email: admin.email };

    const token = await AdminService.generateToken(tokenData, "secretKey", '1h');

    res.status(200).json({ status: true, token: token });
  } catch (error) {
    next(error);
  }
};


