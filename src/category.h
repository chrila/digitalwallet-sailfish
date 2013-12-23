#ifndef CATEGORY_H
#define CATEGORY_H

class Category
{
public:
    Category(const QString name, const QString color);

    QString getName() const;
    QString getColor() const;

private:
    QString name;
    QString color;
};

#endif // CATEGORY_H
