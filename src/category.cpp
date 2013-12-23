#include "category.h"

Category::Category(const QString name, const QString color)
    : name(name), color(color)
{

}

QString Category::getName() const
{
    return name;
}

QString Category::getColor() const
{
    return color;
}
