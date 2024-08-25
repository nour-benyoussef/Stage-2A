const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
const db = require('../config/db');

const { Schema } = mongoose;

const caissierSchema = new Schema({
    nom:{
        type:String,
    },
    prenom:{
        type:String,
    },
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
    telephone:{
        type:Number,
    },
    date_embauche:{
        type:Date,
    },
    Salaire:{
        type:Number,
    }
});

caissierSchema.pre('save',async function(){
    try{
        var caissier = this;
        const salt = await (bcrypt.genSalt(10));
        const hashpass = await bcrypt.hash(caissier.Mot_De_Passe,salt);
        caissier.Mot_De_Passe=hashpass;
    }catch(error){
        throw error;
    }
});

caissierSchema.methods.comparePassword = async function(caissierPassword){
    try{
        const isMatch = await bcrypt.compare(caissierPassword,this.Mot_De_Passe);
        return isMatch;
    }catch(error){
        throw error;
    }
}

const CaissierModel = db.model('caissier',caissierSchema);
module.exports = CaissierModel;
