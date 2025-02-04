// towar.cpp
#include "towar.h"

Towar::Towar(int id, const QString &nazwa, int ilosc, bool czyPrzyjety)
    : id(id), nazwa(nazwa), ilosc(ilosc), czyPrzyjety(czyPrzyjety) {
}

// dodajtowardialog.cpp
#include "dodajtowardialog.h"
#include "ui_dodajtowardialog.h"
#include <QMessageBox>

DodajTowarDialog::DodajTowarDialog(QWidget *parent)
    : QDialog(parent), ui(new Ui::DodajTowarDialog), nowyTowar(nullptr) {
    ui->setupUi(this);
    
    connect(ui->poleIlosc, &QLineEdit::textChanged,
            this, &DodajTowarDialog::sprawdzIlosc);
}

DodajTowarDialog::~DodajTowarDialog() {
    delete ui;
    delete nowyTowar;
}

void DodajTowarDialog::sprawdzIlosc(const QString &tekst) {
    bool ok;
    int ilosc = tekst.toInt(&ok);
    
    if (!ok || ilosc < 0) {
        ui->buttonBox->button(QDialogButtonBox::Ok)->setEnabled(false);
    } else {
        ui->buttonBox->button(QDialogButtonBox::Ok)->setEnabled(true);
    }
}

void DodajTowarDialog::on_buttonBox_accepted() {
    bool ok;
    int id = ui->poleId->text().toInt(&ok);
    if (!ok) {
        QMessageBox::warning(this, "Błąd", "Nieprawidłowy identyfikator!");
        return;
    }

    int ilosc = ui->poleIlosc->text().toInt(&ok);
    if (!ok || ilosc < 0) {
        QMessageBox::warning(this, "Błąd", "Nieprawidłowa ilość!");
        return;
    }

    QString nazwa = ui->poleNazwa->text().trimmed();
    if (nazwa.isEmpty()) {
        QMessageBox::warning(this, "Błąd", "Nazwa nie może być pusta!");
        return;
    }

    nowyTowar = new Towar(id, nazwa, ilosc, ui->przyciskPrzyjety->isChecked());
}

Towar DodajTowarDialog::pobierzTowar() const {
    return nowyTowar ? *nowyTowar : Towar(0, "", 0, true);
}