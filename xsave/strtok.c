#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
	char *str_ori="ab|cd|ef=y";
	char str[strlen(str_ori)];
	char *ptr = NULL;
	char *p = NULL;
	char *left = NULL;

	memset(str,0,sizeof(str));
	memcpy(str, str_ori, strlen(str_ori));
//	strncpy(str, str_ori, strlen(str_ori));
	printf("before strtok:  str=%s\n",str);
	printf("after:\n");
	ptr = strtok_r(str, "|=", &p);
	while(ptr != NULL){
		//ptr = strtok_r(NULL, "|=", &p);
		//if (strlen(p) == 0)
		//	break;
		//printf("str:%s\n",str);
		printf("ptr:%s\n",ptr);
		printf("p:%s\n\n",p);
		ptr = strtok_r(NULL, "|=", &p);
		//left = strchr(p, '=');
		//if (!left)
		//	break;
		if (strlen(p) == 0)
			break;
	}

	printf("str_ori:%s\n", str_ori);
//	free(ptr);
//	free(p);
//	free(left);

	return 0;
}
