import wollok.game.*



/* Clase de vectores. Se pueden instanciar vectores, agregar a sus componentes, blah. */

class Vector
{
	var x
	var y
	
	method x() = x
	method y() = y
	
	method addVector(x_,y_)
	{
		x = x + x_
		y = y + y_
	}
	
	method x (x_){
		x = x_
	}
	
	method y (y_)
	{
		y = y_
	}
	
	
	method scalarMultiply(z)
	{
		x = x * z
		y = y * z
	}
	
	method getCoordinates()
	{
		return game.at(x,y)
	}
	
	method dragX(dragFactor)
	{
		x = (x - (dragFactor * x)).min(0)
	}
}


// Controla el freno del aire, la gravedad y controles de colisiones.

object environment
{
	const gravityVector = new Vector(x = 0, y = -0.003)
	const dragFactor = 0.07
	
	method gravity() = gravityVector
	method dragFactor() = dragFactor
	
	method configureObject()
	{
		keyboard.up().onPressDo({player.moveUp()})
		keyboard.right().onPressDo({player.moveR()})
		keyboard.left().onPressDo({player.moveL()})
		game.whenCollideDo(surface,{x => x.surfaceTouch()})
	}
	
}


// Objeto superficie de prueba para colisiones.
object surface
{
	const position = game.at(game.center().x(),game.center().y() - 1)
	
	method position() = position
	method image() = "ohh.png"
}


// Todo esto es bastante general, se podria crear una clase PlayerController.

object player
{
	// Vectores posicion, aceleracion y velocidad.
	const positionVector = new Vector(x = game.center().x(), y = game.center().y())
	const accelerationVector = environment.gravity()
	const velocityVector = new Vector(x = 0, y = 0)
	// Controlador de que el jugador este creando 
	var tocaPiso = false
	
	method image()
	{
		return "ahh.png"
	}
	
	method velocity() = velocityVector
	
	method surfaceTouch()
	{
		velocityVector.y(velocityVector.y().max(0))
		tocaPiso = true
	}
	
	method touchrem()
	{
		tocaPiso = false
	}
	method moveUp()
	{
		velocityVector.addVector(0,0.2)
	}
	
	method updateVelocity()
	{
		
		if (tocaPiso)
		{
			velocityVector.y(velocityVector.y().max(0)) 
			velocityVector.addVector(accelerationVector.x(),accelerationVector.y().max(0))
		    game.schedule(20,{self.touchrem()})
		}
		else{
			velocityVector.addVector(accelerationVector.x(), accelerationVector.y())
		}
		
		self.drag()
	}
	
	method moveR()
	{
		velocityVector.addVector(0.3,0)
	}
	
	method moveL()
	{
		velocityVector.addVector(-0.3,0)
	}
	
	method drag()
	{
		const dragV =  - self.velocity().x() * environment.dragFactor()
		velocityVector.addVector(dragV,0)
	}
	
	
	// Primero actualiza la velocidad, que en si es actualizada por la gravedad. En el siguiente
	// frame ya la velocidad va a tener el valor inducido por la aceleracion.
	// Despues, actualiza la posicion en base al vector velocidad.
	// Todo esto al menos que este tocando un piso, en ese caso solo
	// se mueve en la direccion del componente horizontal de velocidad dado.
	method updatePosition()
	{
		self.updateVelocity()
		if (tocaPiso){
			positionVector.y(positionVector.y().truncate(0) + 0.09)
			positionVector.addVector(velocityVector.x(),velocityVector.y().max(0))
		}
		else{
		
		positionVector.addVector(velocityVector.x(), velocityVector.y())
		}
		
	}
	
	method position()
	{
		
		self.updatePosition()
		return positionVector.getCoordinates()
		
		
	}
	
}