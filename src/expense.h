#ifndef EXPENSE_H
#define EXPENSE_H

class Expense
{
public:
    Expense(const QDate &date, const float value, const QString &comment, const QString category);

    QDate getDate() const;
    float getValue() const;
    QString getComment() const;
    QString getCategory() const;

private:
    QDate date;
    float value;
    QString comment;
    QString category;
};

#endif // EXPENSE_H
