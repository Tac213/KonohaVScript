class ComponentCreation {
    constructor(url, parent, properties, callback) {
        this.component = undefined;
        this.incubator = undefined;
        this.url = url;
        this.parent = parent;
        this.properties = properties;
        this.callback = callback;
        this.createComponent();
    }

    createComponent() {
        this.component = Qt.createComponent(this.url);
        if (this.component.status === Component.Ready || this.component.status === Component.Error) {
            this.onComponentCreated();
        } else {
            this.component.statusChanged.connect(this.onComponentCreated.bind(this));
        }
    }

    onComponentCreated() {
        if (this.component.status === Component.Ready) {
            this.incubator = this.component.incubateObject(this.parent, this.properties);
            if (this.incubator.status === Component.Ready || this.incubator.status === Component.Ready) {
                this.onElementIncubated(this.incubator.status);
            } else {
                this.incubator.onStatusChanged = this.onElementIncubated.bind(this);
            }
        } else if (this.component.status === Component.Error) {
            console.error('Error loading component:', this.component.errorString());
        }
    }

    onElementIncubated(status) {
        if (status === Component.Ready) {
            if (typeof this.callback === 'function') {
                this.callback(this.incubator.object);
            }
        } else if (status === Component.Ready) {
            console.error('Error incubating object:', this.component.errorString());
        }
    }
}
