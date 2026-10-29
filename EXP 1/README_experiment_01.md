# Experiment 01: ER Diagram for an Indian E-Commerce Platform

Hand-drawn Entity-Relationship (ER) design for an Indian e-commerce platform, covering entities, keys, composite and multivalued attributes, weak entities, specialization, and participation constraints.

## Aim

To design an ER diagram for an Indian e-commerce platform with the entities **Customer, Product, Order, OrderItem, Seller, Category, Payment, Delivery, and Address**, and to specify primary keys, composite and multivalued attributes, weak entities, specialization of Product, and participation constraints.

## Files

| File | Description |
|------|-------------|
| `er_diagram.jpg` | Hand-drawn ER diagram (add your scanned/photographed image under this name) |
| `experiment_01_notes.pdf` | Handwritten notes: aim, theory, notation, participation constraints |

![ER Diagram](er_diagram.jpg)

## Theory

The ER (Entity-Relationship) model, proposed by Peter Chen, is a conceptual model used to design a database. It represents real-world data as **entities**, **attributes**, and **relationships**, independent of any specific DBMS.

### Key Terms

- **Entity**: a real-world object with independent existence (e.g. Customer, Product).
- **Attribute**: a property of an entity. Types:
  - *Simple (atomic)*: cannot be divided further.
  - *Composite*: divisible into parts (e.g. Name = First Name + Last Name).
  - *Single-valued*: holds one value.
  - *Multivalued*: can hold many values (double oval).
  - *Key*: uniquely identifies the entity (underlined).
- **Relationship**: an association between two or more entity instances.
- **Participation constraint**:
  - *Total*: every instance must participate (bold/double line).
  - *Partial*: participation is optional (single line).
- **Weak entity**: has no key of its own and is identified only through its partial key combined with a related strong (owner) entity, connected via a double-diamond identifying relationship (e.g. OrderItem depends on Order).
- **Specialization / Generalization**: dividing an entity into subclasses with distinct attributes (specialization), or combining entities into a superclass (generalization), shown using an ISA triangle (e.g. Product is specialized into Electronics, Fashion, Grocery, and Books).

## Notation Used

| Symbol | Meaning |
|--------|---------|
| Rectangle | Strong entity |
| Double rectangle | Weak entity |
| Diamond | Relationship |
| Double diamond | Identifying relationship |
| Oval | Attribute |
| Double oval | Multivalued attribute |
| Dashed oval | Composite attribute |
| Underlined (solid) | Key attribute |
| Underlined (dashed) | Partial key |
| Triangle labelled ISA | Specialization / Generalization |
| Double / bold line | Total participation |
| Single / thin line | Partial participation |

## Entities and Attributes

| Entity | Type | Key | Notable attributes |
|--------|------|-----|--------------------|
| **Customer** | Strong | Customer ID | Name (composite: First Name, Last Name), Email, Phone (multivalued) |
| **Order** | Strong | Order ID | Order date, Status |
| **OrderItem** | Weak | Item No (partial key) | Quantity |
| **Product** | Strong | Product ID | Title, Price; specialized via ISA |
| **Category** | Strong | Category ID | Name |
| **Seller** | Strong | Seller ID | Business name and related seller details |
| **Payment** | Strong | Payment ID | Mode |
| **Delivery** | Strong | Delivery ID | Status |
| **Address** | Weak | Address ID (partial key) | Phone, Full address (composite: Street, City, State) |

### Specialization of Product

`Product` is specialized through an ISA triangle into:

- Electronics
- Fashion
- Grocery
- Books

## Relationships

| Relationship | Entities | Notes |
|--------------|----------|-------|
| **Places** | Customer, Order | A customer places orders |
| **Has** | Customer, Address (weak) | Identifying relationship; an address belongs to a customer |
| **Contains** | Order, OrderItem (weak) | Identifying relationship; an order item exists only within an order |
| **Refers to** | OrderItem, Product | An order item refers to a product |
| **Sells** | Seller, Product | A seller lists/sells products |
| **Classifies** | Category, Product | A category classifies products |
| **Generates** | Order, Payment | 1:1, total on both sides |
| **Scheduled as** | Order, Delivery | 1:1, total on both sides |
| **Delivered to** | Delivery, Address | Delivery is delivered to an address |

## Participation Constraints

### Total participation

- **Order** in *Places*: an order must have a customer.
- **Address** in *Has*: an address cannot exist without a customer.
- **OrderItem** in *Contains* and *Refers to*: an order item cannot exist without an order.
- **Product** in *Sells* and *Classifies*: every product has a seller and a category.
- **Payment** in *Generates*, and the **Order** side of *Generates* is also total: every order has exactly one payment, and vice versa.
- **Delivery** in *Scheduled as*: same 1:1 total logic on both sides.

### Partial participation

- **Delivery** in *Delivered to*: shown as partial on the delivery side, though logically every delivery needs an address.
- **Customer**, **Seller**, **Category** on their side of their relationships: a customer need not have placed an order yet, and a seller need not have listed a product yet.

## Summary

- 9 entities, including 2 weak entities (OrderItem, Address)
- Composite attributes: Customer Name, Address full address
- Multivalued attribute: Customer Phone
- Specialization: Product into Electronics, Fashion, Grocery, Books
- Two 1:1 total-participation relationships: Order-Payment and Order-Delivery

## License

Provided for educational purposes.
