# docfx-tools

A docfx template for package documentation, patching the modern template to provide stylesheets and scripts for rendering custom workflow containers with copy functionality.

## How to use

To include this template in a docfx website, first clone this repository as a submodule:

```
git submodule add https://github.com/bonsai-rx/docfx-tools bonsai
```

Then modify `docfx.json` to include the template immediately after the modern template:

```json
    "template": [
      "default",
      "modern",
      "bonsai/template",
      "template"
    ],
```

Finally, import and call the modules inside your website `template/public` folder.

#### main.css
```css
@import "workflow.css";
```

#### main.js
```js
import WorkflowContainer from "./workflow.js"

export default {
    start: () => {
        WorkflowContainer.init();
    }
}
```

## Powershell Scripts

This repository also provides helper scripts to automate several content generation steps for package documentation websites.

### Exporting workflow images

Exporting SVG images for all example workflows can be automated by placing all `.bonsai` files in a `workflows` folder and calling the below script pointing to the bin directory to include. A bonsai environment is assumed to be available in the `.bonsai` folder in the repository root.

```ps1
.\modules\Export-Image.ps1 "..\src\PackageName\bin\Release\net472"
```