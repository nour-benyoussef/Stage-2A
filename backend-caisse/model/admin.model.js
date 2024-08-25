const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
const db = require('../config/db');

const { Schema } = mongoose;

const AdminSchema = new Schema({
    email:{
        type:String,
        lowercase:true,
        required :true,
        unique:true
    },
    Mot_De_Passe:{
        type:String,
        required :true,
    },
});

AdminSchema.pre('save',async function(){
    try{
        var admin = this;
        const salt = await (bcrypt.genSalt(10));
        const hashpass = await bcrypt.hash(admin.Mot_De_Passe,salt);
        admin.Mot_De_Passe=hashpass;
    }catch(error){
        throw error;
    }
});

AdminSchema.methods.comparePassword = async function(adminPassword){
    try{
        const isMatch = await bcrypt.compare(adminPassword,this.Mot_De_Passe);
        return isMatch;
    }catch(error){
        throw error;
    }
}

const AdminModel = db.model('admin',AdminSchema);
module.exports = AdminModel;
