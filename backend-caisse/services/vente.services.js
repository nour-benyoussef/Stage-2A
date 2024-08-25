const VenteModel = require('../model/vente.model');
const ArticleModel = require('../model/article.model');

class VenteService {
    static async registerVente(total_vente, type_paiement, email_caissier, date_vente, Monnaie_rendu, articles) {
        try {
            for (const item of articles) {
                const { code, quantite } = item;

                // Récupérer l'article de la base de données
                const article = await ArticleModel.findOne({ code });

                if (!article) {
                    throw new Error(`Article avec le code ${code} n'existe pas`);
                }

                // Vérifier si le stock est suffisant
                if (article.stock < quantite) {
                    throw new Error(`Stock insuffisant pour l'article avec le code ${code}`);
                }

                // Diminuer le stock
                article.stock -= quantite;

                // Vérifier si le stock est maintenant 0
                if (article.stock === 0) {
                    // Supprimer l'article si le stock est 0
                    await ArticleModel.deleteOne({ code });
                } else {
                    // Sinon, enregistrer les modifications de l'article
                    await article.save();
                }
            }

            // Créer et enregistrer la vente
            const createVente = new VenteModel({ total_vente, type_paiement, email_caissier, date_vente, Monnaie_rendu, articles });
            await createVente.save();

            return createVente;
        } catch (err) {
            throw err;
        }
    }

    static async getAllVentes() {
        try {
            return await VenteModel.find().exec(); 
        } catch (err) {
            throw err;
        }
    }
    

    static async countVentes() {
        try {
            return await VenteModel.countDocuments();
        } catch (err) {
            throw err;
        }
    }
}


module.exports = VenteService;
