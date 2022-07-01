export default function updateSmartLoanLibrary(yieldYakRouter, poolManager, solvencyFacetAddress, maxLTV, minSelloutLTV) {
    var fs = require('fs')
    let data = fs.readFileSync('./contracts/lib/SmartLoanLib.sol', 'utf8')

    let fileArray = data.split('\n');

    // MaxLTV

    let lineWithFunctionDeclaration = fileArray.findIndex(
        line => line.includes('_MAX_LTV =')
    );

    let newLine = `    uint256 private constant _MAX_LTV = ${maxLTV};`;

    fileArray.splice(lineWithFunctionDeclaration, 1, newLine);

    //MinSelloutLTV

    lineWithFunctionDeclaration = fileArray.findIndex(
        line => line.includes('_MIN_SELLOUT_LTV =')
    );

    newLine = `    uint256 private constant _MIN_SELLOUT_LTV = ${minSelloutLTV};`;

    fileArray.splice(lineWithFunctionDeclaration, 1, newLine);

    //Yak Router

    lineWithFunctionDeclaration = fileArray.findIndex(
        line => line.includes('return IYieldYakRouter')
    );

    newLine = `    return IYieldYakRouter(${yieldYakRouter});`;

    fileArray.splice(lineWithFunctionDeclaration, 1, newLine);

    //Pool Manager

    lineWithFunctionDeclaration = fileArray.findIndex(
        line => line.includes('return PoolManager')
    );

    newLine = `    return PoolManager(${poolManager});`;

    fileArray.splice(lineWithFunctionDeclaration, 1, newLine);

    //SolvencyFacetAddress

    lineWithFunctionDeclaration = fileArray.findIndex(
        line => line.includes('_SOLVENCY_FACET_ADDRESS =')
    );

    newLine = `    address private constant _SOLVENCY_FACET_ADDRESS = ${solvencyFacetAddress};`;

    fileArray.splice(lineWithFunctionDeclaration, 1, newLine);

    let result = fileArray.join("\n");

    fs.writeFileSync('./contracts/lib/SmartLoanLib.sol', result, 'utf8');

    return 'lib/SmartLoanLib.sol updated!'
}