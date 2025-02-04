#ifndef ADDPLAYERDIALOG_H
#define ADDPLAYERDIALOG_H

#include <QDialog>

namespace Ui {
class AddPlayerDialog;
}

class AddPlayerDialog : public QDialog
{
    Q_OBJECT

public:
    explicit AddPlayerDialog(QWidget *parent = nullptr);
    ~AddPlayerDialog();

    QString getName() const;
    QString getSurname() const;
    int getAge() const;
    int getPoints() const;

private slots:
    void on_okButton_clicked();
    void on_cancelButton_clicked();

private:
    Ui::AddPlayerDialog *ui;
};

#endif // ADDPLAYERDIALOG_H
