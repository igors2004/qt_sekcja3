#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTableWidgetItem>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void addPlayer();     // Slot do dodawania zawodnika
    void removePlayer();  // Slot do usuwania zawodnika
    void showPodium();

private:
    Ui::MainWindow *ui;   // Wskaźnik na UI
};

#endif // MAINWINDOW_H
