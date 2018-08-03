using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using MovieApp.Models;

namespace MovieApp.Controllers
{
    public class HomeController : Controller
    {

        private MoviesDBEntities _db = new MoviesDBEntities(); 
        
        
        //
        // GET: /Home/

        public ActionResult Index()
        {
            return View(_db.MovieSet.ToList());
        }

        //
        // GET: /Home/Details/5

        public ActionResult Details(int id)
        {
            return View();
        }

        //
        // GET: /Home/Create

        public ActionResult Create()
        {
            return View();
        } 

        //
        // POST: /Home/Create

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult Create([Bind(Exclude="Id")] Movie movieToCreate)
        {
             if (!ModelState.IsValid)
                return View();

            _db.AddToMovieSet(movieToCreate);
            _db.SaveChanges();

            return RedirectToAction("Index");
        }

        //
        // GET: /Home/Edit/5

        public ActionResult Edit(int id)
        {
            var movieToEdit = (from m in _db.MovieSet
                               where m.Id == id
                               select m).First();

            return View(movieToEdit);
        }

        //
        // POST: /Home/Edit/5

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult Edit(Movie movieToEdit)
        {

            var originalMovie = (from m in _db.MovieSet
                                 where m.Id == movieToEdit.Id
                                 select m).First();

            if (!ModelState.IsValid)
                return View(originalMovie);

                _db.ApplyPropertyChanges(originalMovie.EntityKey.EntitySetName, movieToEdit);
                _db.SaveChanges();

                return RedirectToAction("Index");
        }

    
    }
}
