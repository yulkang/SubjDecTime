package ScatterAdd;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.event.ActionEvent;
import java.util.*;
import javax.swing.AbstractAction;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import org.jfree.chart.*;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.axis.NumberTickUnit;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYItemRenderer;
import org.jfree.data.xy.XYDataItem;
import org.jfree.data.xy.XYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

/**
%  * @see http://stackoverflow.com/a/13794076/230513
%  * @see http://stackoverflow.com/questions/8430747
%  * @see http://stackoverflow.com/questions/8048652
%  * @see http://stackoverflow.com/questions/7231824
%  * @see http://stackoverflow.com/questions/7205742
%  * @see http://stackoverflow.com/questions/7208657
%  * @see http://stackoverflow.com/questions/7071057
%  * @see http://stackoverflow.com/questions/8736553
%  */
public class ScatterAdd extends JFrame {

    private static final int N = 8;
    private static final int SIZE = 345;
    private static final String title = "Scatter Add Demo";
    private static final Random rand = new Random();
    private final XYSeries series = new XYSeries("Original");
    private final XYSeries added = new XYSeries("Moved");

    public ScatterAdd(String s) {
        super(s);
        final ChartPanel chartPanel = createDemoPanel();
        chartPanel.setPreferredSize(new Dimension(SIZE, SIZE));
        this.add(chartPanel, BorderLayout.CENTER);
        JPanel control = new JPanel();
        control.add(new JButton(new AbstractAction("Move") {

            @Override
            public void actionPerformed(ActionEvent e) {
                for (int i = 0; i < N / 2; i++) {
                    XYDataItem item = series.remove(0);
                    if (item != null) {
                        added.add(item);
                    }
                }
            }
        }));
        this.add(control, BorderLayout.SOUTH);
    }

    private ChartPanel createDemoPanel() {
        JFreeChart jfreechart = ChartFactory.createScatterPlot(
            title, "X", "Y", createSampleData(),
            PlotOrientation.VERTICAL, true, true, false);
        XYPlot xyPlot = (XYPlot) jfreechart.getPlot();
        xyPlot.setDomainCrosshairVisible(true);
        xyPlot.setRangeCrosshairVisible(true);
        XYItemRenderer renderer = xyPlot.getRenderer();
        renderer.setSeriesPaint(0, Color.blue);
        adjustAxis((NumberAxis) xyPlot.getDomainAxis(), true);
        adjustAxis((NumberAxis) xyPlot.getRangeAxis(), false);
        xyPlot.setBackgroundPaint(Color.white);
        return new ChartPanel(jfreechart);
    }

    private void adjustAxis(NumberAxis axis, boolean vertical) {
        axis.setRange(-3.0, 3.0);
        axis.setTickUnit(new NumberTickUnit(0.5));
        axis.setVerticalTickLabels(vertical);
    }

    private XYDataset createSampleData() {
        XYSeriesCollection xySeriesCollection = new XYSeriesCollection();
        for (int i = 0; i < N * N; i++) {
            series.add(rand.nextGaussian(), rand.nextGaussian());
        }
        xySeriesCollection.addSeries(series);
        xySeriesCollection.addSeries(added);
        return xySeriesCollection;
    }

    public static void main(String args[]) {
        EventQueue.invokeLater(new Runnable() {

            @Override
            public void run() {
                ScatterAdd demo = new ScatterAdd(title);
                demo.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
                demo.pack();
                demo.setLocationRelativeTo(null);
                demo.setVisible(true);
            }
        });
    }
}