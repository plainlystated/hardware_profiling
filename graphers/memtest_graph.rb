#!/usr/bin/env ruby
# encoding: utf-8

require 'json'

raise "Usage: #{$0} <results_dir>" unless ARGV.size == 1

results_dir = ARGV.first

series = []
box_lines = Dir[results_dir + "/stream_*.txt"].map do |file|
  box_name = file.match(/stream_(.*).txt/)[1]
  box_data = []
  File.open(file) do |file|
    file.each do |line|
      next if line =~ /^#/
      threads, avg, stddev = *(line.split(' '))
      box_data << avg.to_f
    end
  end
  series << {'name' => box_name, 'data' => box_data}
end.compact

File.open(File.dirname(__FILE__) + "/../memtest.html", "w") do |output|
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
    <title>Memory Speed</title>
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
        text: 'RAM Speed Test',
        x: -20 //center
      },
      xAxis: { title: { text: 'Threads (one per core)' } },
      yAxis: {
        title: {
        text: 'Triads MBps'
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
