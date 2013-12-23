#include "wallet.h"

Wallet::Wallet(const QString name, const QString owner, const float budget, const int budgetType, const QString currency)
    : name(name), owner(owner), budget(budget), budgtType(budgetType), currency(currency)
{

}

QString Wallet::getName() const
{
    return name;
}

QString Wallet::getOwner() const
{
    return owner;
}

float Wallet::getBudget() const
{
    return budget;
}

int Wallet::getBudgetType() const
{
    return budgetType;
}

QString Wallet::getCurrency() const
{
    return currency;
}
