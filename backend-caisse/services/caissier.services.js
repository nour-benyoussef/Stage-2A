const CaissierModel = require('../model/caissier.model')
const jwt = require('jsonwebtoken');
class CaissierService{
    static async registerCaissier(nom,prenom,email,Mot_De_Passe,telephone,date_embauche,Salaire){
        try{
                const createCaissier = new CaissierModel({nom,prenom,email,Mot_De_Passe,telephone,date_embauche,Salaire});
                return await createCaissier.save();
        }catch(err){
            throw err;
        }
    }

    static async checkCaissier (email){
        try{
            return await CaissierModel.findOne({email});
        }catch (error){
            throw error;
        }
    }

    static async generateToken(tokenData,secretKey,jwt_expire){
            return jwt.sign(tokenData,secretKey,{expiresIn:jwt_expire});
    }

    static async getAllCaissiers() {
        try {
            return await CaissierModel.find().exec(); 
        } catch (err) {
            throw err;
        }
    }

    static async getCashierByEmail(email) {
        try {
            return await CaissierModel.findOne({ email }).exec();
        } catch (err) {
            throw err;
        }
    }
    

    static async countCaissiers() {
        try {
            return await CaissierModel.countDocuments();
        } catch (err) {
            throw err;
        }
    }

    static async deleteCaissierByEmail(email) {
        try {
            return await CaissierModel.deleteOne({ email });
        } catch (err) {
            throw err;
        }
    }
    static async updateCaissier(email, updates) {
        try {
            // Utilisation de findOneAndUpdate pour mettre à jour le document
            return await CaissierModel.findOneAndUpdate(
                { email }, 
                { $set: updates }, 
                { new: true, runValidators: true }
            );
        } catch (err) {
            throw err;
        }
    }
}
module.exports = CaissierService;