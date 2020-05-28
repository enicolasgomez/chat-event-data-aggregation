using Microsoft.VisualStudio.TestTools.UnitTesting;
using etl_service_layer.Model;
using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;

namespace etl_service_layer.Model.Tests
{
    [TestClass()]
    public class ETLChatContextTests
    {
        ETLChatContext context = new ETLChatContext();
        [TestMethod()]
        public void GetEventDetailsTestWithoutParameters()
        {
            var events = context.GetEventDetails(null, null);
            Assert.IsTrue(events.Count() > 0);
        }
        [TestMethod()]
        public void GetEventDetailsTestWithParameters()
        {
            var events = context.GetEventDetails(new DateTime(2020, 5, 1, 0, 0, 0), new DateTime(2020, 5, 31, 0, 0, 0));
            Assert.IsTrue(events.Count() > 0);
        }
        [TestMethod()]
        public void GetEventAggregatedDataTest30()
        {
            var events = context.GetAggregatedEvents(30);
            Assert.IsTrue(events.Count() > 0);
        }
        [TestMethod()]
        public void GetEventAggregatedDataTest60()
        {
            var events = context.GetAggregatedEvents(60);
            Assert.IsTrue(events.Count() > 0);
        }
        [TestMethod()]
        public void GetEventAggregatedDataTest240()
        {
            var events = context.GetAggregatedEvents(240);
            Assert.IsTrue(events.Count() > 0);
        }
        [TestMethod()]
        public void GetEventAggregatedDataTest1440()
        {
            var events = context.GetAggregatedEvents(1440);
            Assert.IsTrue(events.Count() > 0);
        }
    }
}