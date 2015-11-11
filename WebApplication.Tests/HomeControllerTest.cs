using System.Web.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using WebApplication.Controllers;

namespace WebApplication.Tests
{
    [TestClass]
    public class HomeControllerTest
    {
        [TestMethod]
        public void About()
        {
            var sut = new HomeController();
            var result = sut.About() as ViewResult;

            Assert.IsNotNull(result);
        }
    }
}
