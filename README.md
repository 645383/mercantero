1. Use the latest stable Rails version +
2. Use Slim view engine -
3. Frontend Framework -
   - React JS (optional)
   - Bootstrap
4. Cover all changes with Rspec tests +
5. Add integration tests using Capybara, Nightwatch.js, Cypress, Puppeteer,
   Protractor or similar -
6. Create factories with FactoryBot +
7. Apply Rubocop and other linters -
8. For Rails models, try to use:
   - Single Table Inheritance (STI) +
   - Polymorphic associations -
   - Scopes -
   - Validations and custom validator object, if necessary +
   - Factory pattern +
   - Demonstrate meta-programming by generating/defining similar predicate
   methods +
   - Encapsulate some logic in a module +
   - Class methods -
   + private section
9. For Rails controllers, try to:
   - Keep them thin +
   - Encapsulate business logic in service objects (1), use cases (2), or similar
   operations (3), interactors (4) +
10. Presentation:
    - Use partials +
    - Define Presenters (View models, Form objects (5)) -
11. Try to showcase background and cron jobs +
12. Dockerize the Application (optional) -

### How to start
1. `bundle exec rspec`
