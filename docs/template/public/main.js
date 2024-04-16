import WorkflowContainer from "./workflow.js"

export default {
    defaultTheme: 'auto',
    iconLinks: [{
        icon: 'github',
        href: 'https://github.com/AllenNeuralDynamics/Bonsai.AllenNeuralDynamics',
        title: 'GitHub'
    }],
    start: () => {
        WorkflowContainer.init();
    }
}