#include <stdio.h>
#include <string.h>
#include <stdlib.h>
//function pointer to point display message
typedef void (*pfnMessage)(const char*,float fResult);
//function pointer to point arithmetic  function
typedef float (*pfnCalculator)(float,float);
//structure of function pointer
typedef struct S_sArithMaticOperation
{
    float iResult;
    pfnMessage DisplayMessage;
    pfnCalculator ArithmaticOperation;
} sArithMaticOperation;
//Perform Addition
float Addition(float a, float b)
{
    return (a + b);
}
//Perform Subtraction
float Subtraction(float a, float b)
{
    return (a - b);
}
//Perform Multiplication
float Multiplication(float a, float b)
{
    return (a*b);
}
//Perform Division
float Division(float a, float b)
{
    return (a/b);
}
//Function display message
void Message(const char *pcMessage, float fResult)
{
    printf("\n\n  %s = %f\n\n\n\n",pcMessage,fResult);
}
//perform Arithmetic operation
void PerformCalculation(float x, float y, sArithMaticOperation
                        *funptr,const char *pcMessage )
{
    //Call function as per the user choice
    float result = funptr->ArithmaticOperation(x,y);
    //Display the Message
    funptr->DisplayMessage(pcMessage,result);
}
int main()
{
    char szMessage[32] = {0};
    int iChoice = 0;
    float fData1 = 0.0f;
    float fData2 = 0.0f;
    sArithMaticOperation *pS = NULL;
    pS = malloc(sizeof(sArithMaticOperation));
    if (pS == NULL)
    {
        return -1;
    }
    pS->DisplayMessage = &Message;
    while(1)
    {
        printf("\n\n  1.Add \n\
  2.Sub \n\
  3.Mul \n\
  4.Div \n\
  5.Exit \n\n\n");
        printf("  Enter the operation Choice = ");
        scanf("%d",&iChoice);
        switch(iChoice)
        {
        case 1 :
            printf("\n  Enter the numbers : ");
            scanf("%f",&fData1);
            printf("\n  Enter the numbers : ");
            scanf("%f",&fData2);
            pS->ArithmaticOperation = &Addition;
            strcpy(szMessage,"Addition of two Number = ");
            break;
        case 2 :
            printf("\n  Enter the numbers :");
            scanf("%f",&fData1);
            printf("\n  Enter the numbers :");
            scanf("%f",&fData2);
            pS->ArithmaticOperation = &Subtraction;
            strcpy(szMessage,"Subtraction of two Number = ");
            break;
        case 3 :
            printf("\n  Enter the numbers :");
            scanf("%f",&fData1);
            printf("\n  Enter the numbers :");
            scanf("%f",&fData2);
            pS->ArithmaticOperation = &Multiplication;
            strcpy(szMessage,"Multiplication of two Number = ");
            break;
        case 4 :
            printf("\n  Enter the numbers :");
            scanf("%f",&fData1);
            printf("\n  Enter the numbers :");
            scanf("%f",&fData2);
            pS->ArithmaticOperation = &Division;
            strcpy(szMessage,"Division of two Number = ");
            break;
        case 5 :
            printf(" \n Invalid Choice :\n\n");
            exit(0);
        }

        //Calling Desire arithmetic function
        PerformCalculation(fData1,fData2,pS,szMessage);
    }
    //Free the allocated memory
    free(pS);
    return 0;
}
