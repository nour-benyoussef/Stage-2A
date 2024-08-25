const ArticleModel = require('../model/article.model')

class ArticleService{
    static async registerArticle(code,nom,description,prix,stock,categorie){
        try{
                const createArticle = new ArticleModel({code,nom,description,prix,stock,categorie});
                return await createArticle.save();
        }catch(err){
            throw err;
        }
    }

    static async getArticleByCode(code) {
        try {
          return await ArticleModel.findOne({ code });
        } catch (err) {
          throw err;
        }
      }

      static async getAllArticles() {
        try {
            return await ArticleModel.find().exec(); 
        } catch (err) {
            throw err;
        }
    }

    static async countArticles() {
      try {
          return await ArticleModel.countDocuments();
      } catch (err) {
          throw err;
      }
  }

  static async updateArticle(code, updateFields) {
    try {
        // La mise à jour n'inclut pas le code, et tous les champs modifiables sont autorisés
        return await ArticleModel.findOneAndUpdate(
            { code },
            { $set: updateFields },
            { new: true } // Retourne le document mis à jour
        );
    } catch (err) {
        throw err;
    }
}
static async deleteArticleByCode(code) {
  try {
      return await ArticleModel.deleteOne({ code });
  } catch (err) {
      throw err;
  }
}
    
}
module.exports = ArticleService;