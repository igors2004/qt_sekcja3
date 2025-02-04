#include "mainwindow.h"
#include "modalwindow.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QWidget>
#include <QHeaderView>
#include <QFileDialog>
#include <QMessageBox>
#include <QFont>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    // Ustawienie tytułu i rozmiaru okna
    setWindowTitle("System Magazynowy - Zarządzanie Towarem");
    resize(800, 600);

    // Utworzenie centralnego widgetu
    QWidget *centralWidget = new QWidget(this);
    setCentralWidget(centralWidget);

    // Główny layout
    QVBoxLayout *mainLayout = new QVBoxLayout(centralWidget);

    // Tytuł aplikacji
    titleLabel = new QLabel("SYSTEM ZARZĄDZANIA MAGAZYNEM", this);
    QFont titleFont = titleLabel->font();
    titleFont.setPointSize(14);
    titleFont.setBold(true);
    titleLabel->setFont(titleFont);
    titleLabel->setAlignment(Qt::AlignCenter);
    mainLayout->addWidget(titleLabel);

    // Panel wyszukiwania
    QHBoxLayout *searchLayout = new QHBoxLayout();
    searchBox = new QLineEdit(this);
    searchBox->setPlaceholderText("Wyszukaj towar...");
    searchButton = new QPushButton("Szukaj", this);
    clearSearchButton = new QPushButton("Wyczyść", this);
    
    searchLayout->addWidget(new QLabel("Wyszukiwarka:"));
    searchLayout->addWidget(searchBox);
    searchLayout->addWidget(searchButton);
    searchLayout->addWidget(clearSearchButton);
    mainLayout->addLayout(searchLayout);

    // Tabela
    tableWidget = new QTableWidget(this);
    tableWidget->setColumnCount(5);
    tableWidget->setHorizontalHeaderLabels({
        "Data operacji",
        "Nazwa towaru",
        "Ilość",
        "Typ operacji",
        "Status"
    });
    
    // Dostosowanie szerokości kolumn
    tableWidget->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    mainLayout->addWidget(tableWidget);

    // Panel przycisków
    QHBoxLayout *buttonLayout = new QHBoxLayout();
    
    addButton = new QPushButton("➕ Dodaj nową operację", this);
    deleteButton = new QPushButton("🗑️ Usuń zaznaczone", this);
    exportButton = new QPushButton("📊 Eksportuj do CSV", this);
    
    buttonLayout->addWidget(addButton);
    buttonLayout->addWidget(deleteButton);
    buttonLayout->addWidget(exportButton);
    mainLayout->addLayout(buttonLayout);

    // Status bar
    statusLabel = new QLabel("Gotowy do pracy", this);
    mainLayout->addWidget(statusLabel);

    // Połączenia sygnałów
    connect(addButton, &QPushButton::clicked, this, &MainWindow::openModalWindow);
    connect(deleteButton, &QPushButton::clicked, this, &MainWindow::deleteSelected);
    connect(exportButton, &QPushButton::clicked, this, &MainWindow::exportData);
    connect(searchButton, &QPushButton::clicked, this, &MainWindow::searchItems);
    connect(clearSearchButton, &QPushButton::clicked, this, &MainWindow::clearSearch);

    // Style CSS
    addButton->setStyleSheet("QPushButton { background-color: #4CAF50; color: white; padding: 5px; }");
    deleteButton->setStyleSheet("QPushButton { background-color: #f44336; color: white; padding: 5px; }");
    exportButton->setStyleSheet("QPushButton { background-color: #2196F3; color: white; padding: 5px; }");
}

void MainWindow::searchItems()
{
    QString searchText = searchBox->text().toLower();
    for(int i = 0; i < tableWidget->rowCount(); ++i) {
        bool match = false;
        for(int j = 0; j < tableWidget->columnCount(); ++j) {
            QTableWidgetItem *item = tableWidget->item(i, j);
            if(item && item->text().toLower().contains(searchText)) {
                match = true;
                break;
            }
        }
        tableWidget->setRowHidden(i, !match);
    }
    statusLabel->setText("Wyszukiwanie zakończone");
}

void MainWindow::clearSearch()
{
    searchBox->clear();
    for(int i = 0; i < tableWidget->rowCount(); ++i) {
        tableWidget->setRowHidden(i, false);
    }
    statusLabel->setText("Wyszukiwanie wyczyszczone");
}

void MainWindow::deleteSelected()
{
    QList<QTableWidgetItem*> selectedItems = tableWidget->selectedItems();
    if(selectedItems.isEmpty()) {
        QMessageBox::warning(this, "Ostrzeżenie", "Nie wybrano żadnych elementów do usunięcia!");
        return;
    }

    QMessageBox::StandardButton reply;
    reply = QMessageBox::question(this, "Potwierdzenie", 
                                "Czy na pewno chcesz usunąć zaznaczone pozycje?",
                                QMessageBox::Yes|QMessageBox::No);
    
    if(reply == QMessageBox::Yes) {
        QSet<int> rowsToRemove;
        for(QTableWidgetItem* item : selectedItems) {
            rowsToRemove.insert(item->row());
        }
        
        QList<int> rows = rowsToRemove.values();
        std::sort(rows.begin(), rows.end(), std::greater<int>());
        
        for(int row : rows) {
            tableWidget->removeRow(row);
        }
        
        statusLabel->setText("Usunięto zaznaczone pozycje");
    }
}

void MainWindow::exportData()
{
    QString fileName = QFileDialog::getSaveFileName(this,
        "Eksportuj dane", "",
        "CSV Files (*.csv);;All Files (*)");
        
    if(fileName.isEmpty())
        return;
        
    QFile file(fileName);
    if(!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QMessageBox::critical(this, "Błąd",
            "Nie można otworzyć pliku do zapisu!");
        return;
    }
    
    QTextStream stream(&file);
    
    // Nagłówki
    QStringList headers;
    for(int i = 0; i < tableWidget->columnCount(); ++i) {
        headers << tableWidget->horizontalHeaderItem(i)->text();
    }
    stream << headers.join(";") << "\n";
    
    // Dane
    for(int row = 0; row < tableWidget->rowCount(); ++row) {
        QStringList rowData;
        for(int col = 0; col < tableWidget->columnCount(); ++col) {
            QTableWidgetItem *item = tableWidget->item(row, col);
            rowData << (item ? item->text() : "");
        }
        stream << rowData.join(";") << "\n";
    }
    
    file.close();
    statusLabel->setText("Dane wyeksportowane do: " + fileName);
}

// Zaktualizowana implementacja dodawania do tabeli
void MainWindow::addItemToTable(const QString& name, int quantity, bool isReceiving)
{
    int row = tableWidget->rowCount();
    tableWidget->insertRow(row);
    
    tableWidget->setItem(row, 0, new QTableWidgetItem(QDate::currentDate().toString("dd.MM.yyyy")));
    tableWidget->setItem(row, 1, new QTableWidgetItem(name));
    tableWidget->setItem(row, 2, new QTableWidgetItem(QString::number(quantity)));
    tableWidget->setItem(row, 3, new QTableWidgetItem(isReceiving ? "Przyjęcie" : "Wydanie"));
    tableWidget->setItem(row, 4, new QTableWidgetItem("Zrealizowano"));
    
    statusLabel->setText("Dodano nową pozycję: " + name);
}

MainWindow::~MainWindow()
{
}