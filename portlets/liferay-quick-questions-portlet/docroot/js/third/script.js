YUI().use('handlebars', 'node-base', function (Y) {

    var newEditTemplate = null,
        allQuestionTemplate = null,
        mainTemplate = null;

    newEditTemplate = Y.Handlebars.compile(Y.one('#new-edit-question-view').getHTML());
    allQuestionTemplate = Y.Handlebars.compile(Y.one('#all-questions-view').getHTML());
    mainTemplate = Y.Handlebars.compile(Y.one('#main-view').getHTML());

    main = mainTemplate({});
    edit = newEditTemplate({});
    all = allQuestionTemplate({});

    var target = Y.one('#sub-content').setHTML(main);

    Y.one('#view').on('click', function (e) {
        target.setHTML(main);
    });

    Y.one('#new').on('click', function (e) {
        target.setHTML(edit);
    });

    Y.on('click', function (e) {
        target.setHTML(all);
    }, '.view-question');

    Y.on('click', function (e) {
        target.setHTML(edit);
    }, '.edit');




});