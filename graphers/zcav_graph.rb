#!/usr/bin/env ruby

require 'json'

raise "Usage: #{$0} <results_dir>" unless ARGV.size == 1

results_dir = ARGV.first

series = []
box_lines = Dir[results_dir + "/*.zcav"].map do |file|
  box_name = file.match(/\/(.*).zcav$/)

  box_data = []
  File.open(file) do |file|
    file.each do |line|
      next if line =~ /^#/
      offset, speed, time = *(line.split(' '))
      box_data << [offset.to_f, speed.to_f]
    end
  end
  series << {'name' => box_name, 'data' => box_data} unless box_data == []
end.compact

File.open(File.dirname(__FILE__) + "/../zcav.html", "w") do |output|
  DATA.each do |line|
    line_gsubbed = line.to_s.sub(/__SERIES__/, series.to_json)
    output.puts line_gsubbed
  end
end


__END__
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>ZCAV test</title>
    <script type='text/javascript' src='https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'></script>
    <script type='text/javascript'>//<![CDATA[

      $(function () {
      var chart;
      $(document).ready(function() {
        chart = new Highcharts.Chart({
        chart: {
        renderTo: 'container',
        type: 'line',
        marginRight: 130,
        marginBottom: 50
      },
      title: {
        text: 'ZCAV',
        x: -20 //center
      },
      xAxis: { title: { text: 'Offset' } },
      yAxis: {
        title: {
          text: 'MB/s'
        },
        plotLines: [{
          value: 0,
          width: 1,
          color: '#808080'
        }]
      },
        tooltip: {
          formatter: function() {
          return '<b>'+ this.series.name +'</b><br/>'+
          this.x +': '+ this.y;
        }
      },
        legend: {
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'top',
        x: -10,
        y: 100,
        borderWidth: 0
      },
      series: __SERIES__
      });
      });

    });
    //]]>
    </script>
  </head>
  <body>
    <script src="http://code.highcharts.com/highcharts.js"></script>
    <script src="http://code.highcharts.com/modules/exporting.js"></script>

    <div id="container" style="min-width: 400px; height: 800px; margin: 0 auto"></div>
  </body>
</html>
