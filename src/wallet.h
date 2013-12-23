#ifndef WALLET_H
#define WALLET_H

class Wallet
{
public:
    Wallet(const QString name, const QString owner, const float budget, const int budgetType, const QString currency);

    QString getName() const;
    QString getOwner() const;
    float getBudget() const;
    int getBudgetType() const;
    QString getCurrency() const;

private:
    QString name;
    QString owner;
    float budget;
    int budgetType;
    QString currency;
};

#endif // WALLET_H
