const CaissierService = require("../services/caissier.services");

function convertDateString(dateString) {
  const [day, month, year] = dateString.split('/');
  return `${year}-${month}-${day}`;
}

exports.register = async (req, res, next) => {
  try {
    const { nom, prenom, email, Mot_De_Passe, telephone, date_embauche, Salaire } = req.body;

    // Convert date_embauche to the correct format if it exists
    let formattedDateEmbauche = null;
    if (date_embauche) {
      formattedDateEmbauche = new Date(convertDateString(date_embauche));
    }

    const successRes = await CaissierService.registerCaissier(
      nom,
      prenom,
      email,
      Mot_De_Passe,
      telephone,
      formattedDateEmbauche,
      Salaire
    );

    res.json({ status: true, success: "Caissier enregistré" });
  } catch (error) {
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, Mot_De_Passe } = req.body;

    const caissier = await CaissierService.checkCaissier(email);

    if (!caissier) {
      // Si le caissier n'est pas trouvé, retourner status: false
      return res.status(404).json({ status: false, message: "identifiant incorrect " });
    }

    const isMatch = await caissier.comparePassword(Mot_De_Passe);

    if (!isMatch) {
      // Si le mot de passe est incorrect, retourner status: false
      return res.status(401).json({ status: false, message: "Mot de passe incorrect" });
    }

    let tokenData = { _id: caissier._id, email: caissier.email };

    const token = await CaissierService.generateToken(tokenData, "secretKey", '1h');

    res.status(200).json({ status: true, token: token, nom: caissier.nom, prenom:caissier.prenom });
  } catch (error) {
    next(error);
  }
};


exports.getAllCaissiers = async (req, res, next) => {
  try {
      const caissiers = await CaissierService.getAllCaissiers();
      res.json({ status: true, caissiers: caissiers });
  } catch (error) {
      next(error);
  }
};


exports.countCaissiers = async (req, res, next) => {
  try {
      const totalCaissiers = await CaissierService.countCaissiers();
      res.json({ status: true, total: totalCaissiers });
  } catch (error) {
      next(error);
  }
};


exports.deleteCaissier = async (req, res, next) => {
  try {
      const { email } = req.params; 

      const result = await CaissierService.deleteCaissierByEmail(email);

      if (result.deletedCount > 0) {
          res.json({ status: true, message: "Caissier supprimé avec succès" });
      } else {
          res.json({ status: false, message: "Caissier non trouvé" });
      }
  } catch (error) {
      next(error);
  }
};

// caissier.controller.js
exports.updateCaissier = async (req, res, next) => {
  try {
      const { email, nom, prenom, telephone, Salaire } = req.body;

      if (!email) {
          return res.status(400).json({ status: false, message: "L'email est requis" });
      }

      // Préparer les données de mise à jour
      const updates = { nom, prenom, telephone, Salaire };

      // Appel au service pour mettre à jour les informations
      const updatedCaissier = await CaissierService.updateCaissier(email, updates);

      if (updatedCaissier) {
          res.json({ status: true, message: "Caissier mis à jour avec succès", caissier: updatedCaissier });
      } else {
          res.json({ status: false, message: "Caissier non trouvé" });
      }
  } catch (error) {
      next(error);
  }
};


exports.getCashierByEmail = async (req, res, next) => {
  try {
      const { email } = req.params;
      const caissier = await CaissierService.getCashierByEmail(email);

      if (caissier) {
          res.json({ status: true, caissier:caissier });
      } else {
          res.json({ status: false, message: "Caissier non trouvé" });
      }
  } catch (error) {
      next(error);
  }
};
