#include <security/pam_appl.h>
#include <security/pam_misc.h>
#include <stdio.h>

struct my_pam_appdata {
    char *password;
};

int my_conv(int num_msg, const struct pam_message **msg, struct pam_response **resp, void *appdata_ptr) {
    pam_response *addr = (pam_response*)calloc(num_msg, sizeof(pam_response));
    resp[0] = addr;

    my_pam_appdata *appdata = (my_pam_appdata*)(appdata_ptr);
    // std::cout << num_msg << std::endl;
    // for(int i=0; i<num_msg; i++) {
        if(msg[0]->msg_style == PAM_PROMPT_ECHO_OFF) {
            resp[0]->resp = strdup(appdata->password);
            resp[0]->resp_retcode = 0;
        }
    // }
    return 0;
}

static struct pam_conv conv = {
    *my_conv,
    NULL
};

extern "C" int pamjl_authenticate(char *user, char *pass) {
    char* service = (char*)"login";
    int resetcred = PAM_REINITIALIZE_CRED;

    pam_handle_t *pamh=NULL;
    int retval;

    my_pam_appdata appdata = {
        pass
    };
    conv.appdata_ptr = (void*)(&appdata);

    retval = pam_start(service, user, &conv, &pamh);

    if (retval == PAM_SUCCESS) {
        retval = pam_authenticate(pamh, 0);    /* is user really user? */
        if(retval != PAM_SUCCESS) {
            fprintf(stderr, "%s: pam_authenticate failed: %s\n", service, pam_strerror(pamh, retval));
        }
    }
    else {
        fprintf(stderr, "%s: pam_start failed: %s\n", service, pam_strerror(pamh, retval));
		return 1;
    }

    if(retval == PAM_SUCCESS) {
        retval = pam_acct_mgmt(pamh, 0);       /* permitted access? */
        if(retval != PAM_SUCCESS) {
            fprintf(stderr, "%s: pam_acct_mgmt failed: %s\n", service, pam_strerror(pamh, retval));
        }
    }
    
    /* This is where we have been authorized or not. */

    if (retval == PAM_SUCCESS) {
        // reset credentials (https://github.com/minrk/pamela/blob/master/pamela.py#L380)
        retval = pam_setcred(pamh, resetcred);
        if(retval != PAM_SUCCESS) {
            fprintf(stderr, "%s: pam_setcred failed: %s\n", service, pam_strerror(pamh, retval));
        }
    }

    if (pam_end(pamh, retval) != PAM_SUCCESS) {     /* close Linux-PAM */
        fprintf(stderr, "%s: pam_end failed: %s\n", service, pam_strerror(pamh, retval));
    }

    return (retval == PAM_SUCCESS ? 0 : 1);       /* indicate success */
}
