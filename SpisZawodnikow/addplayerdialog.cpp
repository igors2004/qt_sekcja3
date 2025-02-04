#include "addplayerdialog.h"
#include "ui_addplayerdialog.h"

AddPlayerDialog::AddPlayerDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::AddPlayerDialog)
{
    ui->setupUi(this);
}

AddPlayerDialog::~AddPlayerDialog()
{
    delete ui;
}

QString AddPlayerDialog::getName() const
{
    return ui->nameLineEdit->text();
}

QString AddPlayerDialog::getSurname() const
{
    return ui->surnameLineEdit->text();
}

int AddPlayerDialog::getAge() const
{
    return ui->ageSpinBox->value();
}

int AddPlayerDialog::getPoints() const
{
    return ui->pointsSpinBox->value();
}

void AddPlayerDialog::on_okButton_clicked()
{
    accept();
}

void AddPlayerDialog::on_cancelButton_clicked()
{
    reject();
}
