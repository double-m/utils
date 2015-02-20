package com.marcellomessori.myprojectname;

import static org.junit.Assert.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

public class LogicTest {

    @Before
    public void setUp() {
    }

    @After
    public void tearDown() {
    }

	@Test
	public void shouldSayHelloToTheWorldTest() {
		Logic instance = new Logic();
		String expectedResult = "Hello World!";
		String result = instance.sayHelloToTheWorld();
		assertEquals(expectedResult, result);
	}

	@Ignore
	public void nextTest() {
		
	}
}
