const ArticleService = require("../services/article.services");


exports.register = async (req, res, next) => {
  try {
    const {code,nom, description, prix, stock, categorie } = req.body;

 

    const successRes = await ArticleService.registerArticle(
    code,
      nom,
      description,
      prix,
      stock,
      categorie, 
    );

    res.json({ status: true, success: "article enregistré" });
  } catch (error) {
    next(error);
  }
};

exports.getArticle = async (req, res, next) => {
    try {
        const { code } = req.body; 
        const article = await ArticleService.getArticleByCode(code);
  
      if (article) {
        res.json({ status: true, article });
      } else {
        res.json({ status: false, message: "Article non trouvé" });
      }
    } catch (error) {
      next(error);
    }
  };
  exports.getArticle1 = async (req, res, next) => {
    try {
        const { code } = req.params; 
        const article = await ArticleService.getArticleByCode(code);
  
      if (article) {
        res.json({ status: true, article });
      } else {
        res.json({ status: false, message: "Article non trouvé" });
      }
    } catch (error) {
      next(error);
    }
  };

  exports.getAllArticles = async (req, res, next) => {
    try {
        const articles = await ArticleService.getAllArticles();
        res.json({ status: true, articles: articles });
    } catch (error) {
        next(error);
    }
};

exports.countArticles = async (req, res, next) => {
  try {
      const totalArticles = await ArticleService.countArticles();
      res.json({ status: true, total: totalArticles });
  } catch (error) {
      next(error);
  }
};


exports.updateArticle = async (req, res, next) => {
  try {
      const { code } = req.body; // Code de l'article à mettre à jour
      const { nom, description, prix, stock, categorie } = req.body; // Champs modifiables

      // Validation pour s'assurer que seuls les champs modifiables sont présents
      if (Object.keys(req.body).length === 0) {
          return res.status(400).json({ status: false, message: "Aucune donnée fournie pour la mise à jour." });
      }

      // Exclure le code des champs modifiables
      const updateFields = { nom, description, prix, stock, categorie };

      const updatedArticle = await ArticleService.updateArticle(code, updateFields);

      if (updatedArticle) {
          res.json({ status: true, article: updatedArticle, message: "Article modifié avec succès" });
      } else {
          res.json({ status: false, message: "Article non trouvé" });
      }
  } catch (error) {
      next(error);
  }
};



exports.deleteArticle = async (req, res, next) => {
  try {
      const { code } = req.params; 

      const result = await ArticleService.deleteArticleByCode(code);

      if (result.deletedCount > 0) {
          res.json({ status: true, message: "Article supprimé avec succès" });
      } else {
          res.json({ status: false, message: "Article non trouvé" });
      }
  } catch (error) {
      next(error);
  }
};
