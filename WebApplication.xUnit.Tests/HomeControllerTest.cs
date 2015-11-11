using System.Web.Mvc;
using WebApplication.Controllers;
using Xunit;

namespace WebApplication.xUnit.Tests
{
    public class HomeControllerTest
    {
        [Fact]
        public void Contact()
        {
            var sut = new HomeController();
            var result = sut.Contact() as ViewResult;

            Assert.NotNull(result);
        }
    }
}
