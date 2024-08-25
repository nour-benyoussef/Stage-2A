const AdminModel = require('../model/admin.model')
const jwt = require('jsonwebtoken');
class AdminService{
    static async registerAdmin(email,Mot_De_Passe){
        try{
                const createAdmin = new AdminModel({email,Mot_De_Passe});
                return await createAdmin.save();
        }catch(err){
            throw err;
        }
    }

    static async checkAdmin (email){
        try{
            return await AdminModel.findOne({email});
        }catch (error){
            throw error;
        }
    }

    static async generateToken(tokenData,secretKey,jwt_expire){
            return jwt.sign(tokenData,secretKey,{expiresIn:jwt_expire});
    }

}
module.exports = AdminService;