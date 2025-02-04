// mainwindow.cpp
#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QPixmap>
#include <QMessageBox>
#include <algorithm>

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);
    wczytajLogo();
    ustawTabele();
}

MainWindow::~MainWindow() {
    delete ui;
}

void MainWindow::wczytajLogo() {
    QPixmap logo(":/obrazy/logo.png");
    ui->etykietaLogo->setPixmap(logo.scaled(200, 100, Qt::KeepAspectRatio));
}

void MainWindow::ustawTabele() {
    ui->tabelaTowarow->setColumnCount(4);
    ui->tabelaTowarow->setHorizontalHeaderLabels({"ID", "Nazwa", "Ilość", "Status"});
    ui->tabelaTowarow->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
}

void MainWindow::on_przyciskDodaj_clicked() {
    DodajTowarDialog dialog(this);
    if (dialog.exec() == QDialog::Accepted) {
        towary.push_back(dialog.pobierzTowar());
        aktualizujListeTowarow();
    }
}

void MainWindow::aktualizujListeTowarow() {
    // Sortowanie towarów po nazwie
    std::sort(towary.begin(), towary.end(), 
              [](const Towar &a, const Towar &b) { return a.pobierzNazwe() < b.pobierzNazwe(); });

    ui->tabelaTowarow->setRowCount(towary.size());

    for (int i = 0; i < towary.size(); ++i) {
        ui->tabelaTowarow->setItem(i, 0, new QTableWidgetItem(QString::number(towary[i].pobierzId())));
        ui->tabelaTowarow->setItem(i, 1, new QTableWidgetItem(towary[i].pobierzNazwe()));
        ui->tabelaTowarow->setItem(i, 2, new QTableWidgetItem(QString::number(towary[i].pobierzIlosc())));
        ui->tabelaTowarow->setItem(i, 3, new QTableWidgetItem(towary[i].czyJestPrzyjety() ? "Przyjęty" : "Wydany"));
    }
}

void MainWindow::on_przyciskPokaz_clicked() {
    Towar *maxPrzyjety = nullptr;
    Towar *maxWydany = nullptr;

    for (const Towar &towar : towary) {
        if (towar.czyJestPrzyjety()) {
            if (!maxPrzyjety || towar.pobierzIlosc() > maxPrzyjety->pobierzIlosc()) {
                maxPrzyjety = const_cast<Towar*>(&towar);
            }
        } else {
            if (!maxWydany || towar.pobierzIlosc() > maxWydany->pobierzIlosc()) {
                maxWydany = const_cast<Towar*>(&towar);
            }
        }
    }

    QString komunikat = "Największe ilości:\n\n";
    if (maxPrzyjety) {
        komunikat += QString("Przyjęty: ID %1 - %2 (%3 szt.)\n")
            .arg(maxPrzyjety->pobierzId())
            .arg(maxPrzyjety->pobierzNazwe())
            .arg(maxPrzyjety->pobierzIlosc());
    }
    if (maxWydany) {
        komunikat += QString("Wydany: ID %1 - %2 (%3 szt.)")
            .arg(maxWydany->pobierzId())
            .arg(maxWydany->pobierzNazwe())
            .arg(maxWydany->pobierzIlosc());
    }

    QMessageBox::information(this, "Statystyki", komunikat);
}