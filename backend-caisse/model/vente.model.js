const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const VenteSchema = new Schema({
    total_vente: Number,
    type_paiement: String,
    email_caissier: String,
    date_vente: Date,
    Monnaie_rendu :Number,
    articles: [
        {
            code: String,
            nom: String,
            description: String,
            prix: Number,
            quantite: Number
        }
    ]
});

const VenteModel = db.model('vente', VenteSchema);
module.exports = VenteModel;
