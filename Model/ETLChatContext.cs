using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.Common;
using System.Threading.Tasks;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace etl_service_layer.Model
{
  public class ETLChatContext : DbContext
  {
    public DbSet<Event> Events { get; set; }
    //public DbSet<AggregatedEvents> AggregatedEvents { get; set; }
    public IConfigurationRoot Configuration { get; } 
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
      optionsBuilder.UseSqlServer("Server=localhost; Database=PD3; Integrated Security=True;");
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
      //builder.Entity<AggregatedEvents>(sd =>
      //{
      //  sd.HasNoKey().ToView(null);
      //});

      base.OnModelCreating(builder);
      // Customize the ASP.NET Identity model and override the defaults if needed.
      // For example, you can rename the ASP.NET Identity table names and more.
      // Add your customizations after calling base.OnModelCreating(builder);
    }

    public IEnumerable<Event> GetEventDetails(DateTime? start, DateTime? end)
    {
      List<Event> ae = new List<Event>();
      using (var context = new ETLChatContext())
      {
        string sql = String.Format("spTransactionSelect @startDate = '{0}',@endDate = '{1}'", "1/1/1975 12:00:00 AM", "1/1/2025 12:00:00 AM");
        ae = context.Events.FromSqlRaw(sql).ToList(); // WHERE [Date] > '"+Convert.ToString(start)+"' AND[Date] < '" + Convert.ToString(end) + "'").ToList();
      }
      return ae;
    }

    public IEnumerable<AggregatedEvents> GetAggregatedEvents(int minutes)
    {
      List<AggregatedEvents> ae = new List<AggregatedEvents>();

      //using (var context = new ETLChatContext())
      //{
      //  string sql = String.Format("SELECT [StartDate],[EndDate],[Enter],[Leave],[Comment],[HiFive] FROM [Event_Agg_15]");
      //  int r = context.Database.ExecuteSqlRaw< AggregatedEvents>(sql);
      //}
      //return ae;

      //as the above is not supported on Core 2.0 EF 3.1 we are going back 10 years to ADO.NET SqlCommand :) goodbye POCO friendly interfaces

      using (var context = new ETLChatContext())
      {
        using (var command = context.Database.GetDbConnection().CreateCommand())
        {
          if (command.Connection.State != ConnectionState.Open)
            command.Connection.Open();
          command.CommandText = "Exec spAggregateSelect @minutes = " + minutes;
          DbDataReader reader = command.ExecuteReader();
          while (reader.Read())
          {
            ae.Add(new AggregatedEvents()
            {
              StartDate = Convert.ToDateTime(reader["StartDate"]),
              EndDate = Convert.ToDateTime(reader["EndDate"]),
              Enter = Convert.ToInt32(reader["Enter"]),
              Leave = Convert.ToInt32(reader["Leave"]),
              Comment = Convert.ToInt32(reader["Comment"]),
              HiFive = Convert.ToInt32(reader["HiFive"])
            });
          }
        }
      }

      return ae;
    }
  }
}
