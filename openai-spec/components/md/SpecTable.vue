<template>
    <div class="spec-table-wrap" :style="style">
        <table class="spec">
            <thead v-if="headers && headers.length">
                <tr>
                    <th v-for="(h, i) in headers" :key="i" v-html="h"></th>
                </tr>
            </thead>
            <tbody><slot></slot></tbody>
        </table>
    </div>
</template>
<script>
    export default {
        name: 'SpecTable',
        props: {
            headers: { type: Array, default: function () { return []; } },
            marginTop: { type: String, default: '' }
        },
        computed: {
            style: function () {
                return this.marginTop ? 'margin-top:' + this.marginTop + ';' : '';
            }
        }
    };
</script>
