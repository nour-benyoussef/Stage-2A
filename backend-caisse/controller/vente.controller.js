const VenteService = require('../services/vente.services');

exports.register = async (req, res, next) => {
    try {
        const { total_vente, type_paiement, email_caissier, date_vente, Monnaie_rendu, articles } = req.body;

        const successRes = await VenteService.registerVente(total_vente, type_paiement, email_caissier, date_vente, Monnaie_rendu, articles);

        res.json({ status: true, message: 'Vente enregistrée avec succès' });
    } catch (error) {
        res.status(400).json({ status: false, message: error.message });
    }
};



exports.getAllVentes = async (req, res, next) => {
    try {
        const ventes = await VenteService.getAllVentes();
        res.json({ status: true, ventes: ventes });
    } catch (error) {
        next(error);
    }
};

exports.countVentes = async (req, res, next) => {
    try {
        const totalVentes = await VenteService.countVentes();
        res.json({ status: true, total: totalVentes });
    } catch (error) {
        next(error);
    }
};



