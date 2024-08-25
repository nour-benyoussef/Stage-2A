const router = require ('express').Router();
const ArticleController = require("../controller/article.controller")

router.post('/registerArticle',ArticleController.register);
router.post('/getArticle', ArticleController.getArticle);  
router.get('/allArticles', ArticleController.getAllArticles); 
router.get('/CountArticles', ArticleController.countArticles); 
router.put('/updateArticle', ArticleController.updateArticle);
router.delete('/deleteArticle/:code', ArticleController.deleteArticle);
router.get('/getArticle/:code', ArticleController.getArticle1);  

module.exports = router;