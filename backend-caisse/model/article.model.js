const mongoose = require('mongoose');
const db = require('../config/db');

const { Schema } = mongoose;

const ArticleSchema = new Schema({
    code:{
        type:String,
        unique:true
    },
    nom:{
        type:String,
    },
    description:{
        type:String,
    },
    prix:{
        type:Number,
    },
    stock:{
        type:Number,
    },
    categorie:{
        type:String,
    },
});


const ArticleModel = db.model('article',ArticleSchema);
module.exports = ArticleModel;
