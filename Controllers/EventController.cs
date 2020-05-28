using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using etl_service_layer.Model;

namespace etl_service_layer.Controllers
{
  [ApiController]
  [Route("[controller]")]
  public class EventController : ControllerBase
  {
    private readonly ILogger<EventController> _logger;

    public EventController(ILogger<EventController> logger)
    {
      _logger = logger;
    }

    [HttpGet("/event/geteventtransactions")]
    public IEnumerable<Event> GetEventTransactions(DateTime start, DateTime end)
    {
      using (var context = new ETLChatContext())
      {
        return context.GetEventDetails(start, end);
      }
    }

    [HttpGet("/event/geteventaggregated")]
    public IEnumerable<AggregatedEvents> GetEventAggregated(int minutes) //this queries the events ETL
    {
      using (var context = new ETLChatContext())
      {
        return context.GetAggregatedEvents(minutes);
      }
    }
  }
}
