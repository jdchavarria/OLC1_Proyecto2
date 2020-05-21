var fs = require('fs'); 
var parser = require('./gramatica');

//let ast;
fs.readFile('./entrada.txt', (err, data) => {
    if (err) throw err;
    let ast = parser.parse(data.toString());  //LE PASO A LA VARIABLE AST LO QUE RETORNA EL PARSER 
    console.log(ast);   //SOLO MUESTRA PARA CORROBORAR
    fs.writeFileSync('./ast.json',JSON.stringify(ast,null,2));  //CREO UN ARCHIVO ast.json CON EL CONTENIDO DE LA VARIBLE ast
});
