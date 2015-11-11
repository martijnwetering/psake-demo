using System.Web.Mvc;
using NUnit.Framework;
using WebApplication.Controllers;

namespace WebApplication.NUnit.Tests
{
    [TestFixture]
    public class HomeControllerTest
    {
        [Test]
        public void Index()
        {
            var sut = new HomeController();
            var result = sut.Index() as ViewResult;

            Assert.IsNotNull(result);
        }
    }
}
