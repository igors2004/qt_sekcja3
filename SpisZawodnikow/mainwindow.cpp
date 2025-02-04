#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "addplayerdialog.h"
#include <QMessageBox>
#include <QInputDialog>
#include <QLabel>
#include <QPixmap>
#include <QPushButton>
#include <QPair>
#include <QVector>
#include <algorithm>  // Do sortowania

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // Ustawienie tabeli
    ui->tableWidget->setColumnCount(4);  // 4 kolumny: Imię, Nazwisko, Wiek, Punkty
    ui->tableWidget->setHorizontalHeaderLabels(QStringList() << "Imię" << "Nazwisko" << "Wiek" << "Punkty");

    // Przyciski
    connect(ui->addButton, &QPushButton::clicked, this, &MainWindow::addPlayer);  // Przycisk "Dodaj"
    connect(ui->removeButton, &QPushButton::clicked, this, &MainWindow::removePlayer);  // Przycisk "Usuń"
    connect(ui->podiumButton, &QPushButton::clicked, this, &MainWindow::showPodium);  // Przycisk "Podium"

    // Wstawianie logo klubu
    QPixmap logo(":/images/logo.png");  // Upewnij się, że masz odpowiednią ścieżkę do obrazu
    ui->logoLabel->setPixmap(logo);
    ui->logoLabel->setScaledContents(true);  // Dopasowanie rozmiaru logo do QLabel
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::addPlayer()
{
    // Otwórz okno dialogowe do wprowadzania danych zawodnika
    AddPlayerDialog dialog(this);
    if (dialog.exec() == QDialog::Accepted) {
        // Pobierz dane z okna dialogowego
        QString name = dialog.getName();
        QString surname = dialog.getSurname();
        int age = dialog.getAge();
        int points = dialog.getPoints();

        // Dodaj zawodnika do tabeli
        int row = ui->tableWidget->rowCount();
        ui->tableWidget->insertRow(row);  // Dodaj nowy wiersz


         ui->tableWidget->setItem(row, 2, new QTableWidgetItem(QString::number(age)));  // Ustawienie wieku
        ui->tableWidget->setItem(row, 0, new QTableWidgetItem(name));  // Ustawienie imienia
        ui->tableWidget->setItem(row, 1, new QTableWidgetItem(surname));  // Ustawienie nazwiska
        ui->tableWidget->setItem(row, 3, new QTableWidgetItem(QString::number(points)));  // Ustawienie punktów
         ui->tableWidget->sortItems(3, Qt::DescendingOrder);  // Sortowanie po kolumnie 3 (Punkty) malejąco
    }
}

void MainWindow::removePlayer()
{
    // Usunięcie zaznaczonego zawodnika z tabeli
    int row = ui->tableWidget->currentRow();
    if (row != -1) {
        ui->tableWidget->removeRow(row);  // Usuwanie wiersza
    } else {
        QMessageBox::warning(this, "Błąd", "Nie wybrano zawodnika do usunięcia.");
    }
}

void MainWindow::showPodium()
{
    // Funkcja do wyznaczania podium (top 3 zawodników)
    int rowCount = ui->tableWidget->rowCount();
    QVector<QPair<int, int>> points;  // Wejście: wektor <wiersz, punkty>

    for (int i = 0; i < rowCount; ++i) {
        int pointsVal = ui->tableWidget->item(i, 3)->text().toInt();  // Pobierz punkty
        points.append(qMakePair(i, pointsVal));  // Dodaj wiersz i punkty
    }

    // Sortowanie po punktach malejąco
    std::sort(points.begin(), points.end(), [](const QPair<int, int>& a, const QPair<int, int>& b) {
        return a.second > b.second;  // Porównanie punktów
    });

    // Pokazujemy 3 najlepszych
    QString podiumText = "Podium:\n";
    for (int i = 0; i < 3 && i < points.size(); ++i) {
        int row = points[i].first;
        QString name = ui->tableWidget->item(row, 0)->text();  // Imię
        QString surname = ui->tableWidget->item(row, 1)->text();  // Nazwisko
        int points = ui->tableWidget->item(row, 3)->text().toInt();  // Punkty
        podiumText += QString("%1 %2 - %3 punktów\n").arg(name, surname).arg(points);
    }

    QMessageBox::information(this, "Podium", podiumText);  // Pokazanie podium w oknie komunikatu
}
