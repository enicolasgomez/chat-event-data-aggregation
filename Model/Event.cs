using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace etl_service_layer.Model
{
  public class Event
  {
    public int ID { get; set; }
    public string? Text { get; set; }
    public string UserName { get; set; }
    public string? TargetUserName { get; set; }
    public string EventType { get; set; }
    public DateTime Date { get; set; }

  }
}
